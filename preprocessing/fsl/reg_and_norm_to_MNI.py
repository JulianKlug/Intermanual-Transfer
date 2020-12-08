import os, subprocess
from nipype.interfaces import fsl


def register_and_normalize(functional_file, structural_file, ref_file, out_file=None):
    '''
    Coregistration & Normalization of a functional 4D file
    :param functional_file: path to input 4D functional file
    :param structural_file: path to input 4D structural file
    :param ref_file: reference file to co-register the source-file to
    :param out_file: output file
    :return: path to coregistered and normalized file
    '''

    # bet my_structural my_betted_structural
    # flirt -ref my_betted_structural -in my_functional -dof 6 -omat func2struct.mat
    # flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in my_betted_structural -omat my_affine_transf.mat
    # fnirt --in=my_structural --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm
    # applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_functional --warp=my_nonlinear_transf --premat=func2struct.mat --out=my_warped_functional

    functional_dir, functional_file_name = os.path.split(functional_file)
    structural_dir, structural_file_name = os.path.split(structural_file)
    if out_file is None:
        out_file = os.path.join(functional_dir, 'wr' + functional_file_name)

    btr = fsl.BET()
    btr.inputs.in_file = structural_file
    btr.inputs.frac = 0.7
    btr.inputs.out_file = os.path.join(structural_dir, 'betted_' + structural_file_name)
    btr_res = btr.run()

    flt = fsl.FLIRT(bins=640, cost_func='mutualinfo')
    flt.inputs.in_file = btr_res.outputs.out_file + '.gz'
    flt.inputs.reference = ref_file
    flt.inputs.out_matrix_file = os.path.join(structural_dir, 'affine_transf.mat')
    flt_res = flt.run()

    # Problem with nipype implementation is that it requires a seperate ref file
    # fnt = fsl.FNIRT(affine_file=os.path.join(structural_dir, 'affine_transf.mat'))
    # fnt.inputs.in_file = structural_file
    # fnt.inputs.ref_file = 'ref_file'
    # fnt.inputs.config_file = 'T1_2_MNI152_2mm'
    # fnt.inputs.fieldcoeff_file = os.path.join(structural_dir, 'nonlinear_transf')
    # fnt_res = fnt.run()

    # fnirt --in=my_structural --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm
    fnirt_cli = ['fnirt',
                 f'--in={structural_file}',
                 f"--aff={os.path.join(structural_dir, 'affine_transf.mat')}",
                 f"--cout={os.path.join(structural_dir, 'nonlinear_transf')}",
                 f'--config=T1_2_MNI152_2mm'
                 ]

    print(str(fnirt_cli))
    subprocess.run(fnirt_cli, cwd=structural_dir)

    aw = fsl.ApplyWarp()
    aw.inputs.in_file = functional_file
    aw.inputs.ref_file = ref_file
    aw.inputs.field_file = os.path.join(structural_dir, 'nonlinear_transf')
    aw.inputs.out_file = out_file
    aw_res = aw.run()

    return out_file

register_and_normalize('/Users/jk1/temp/fmri_test/data/test2/4d_bold.nii.gz',
                       '/Users/jk1/temp/fmri_test/data/test2/sY19930524-152659-00001-00176-1.nii',
                       '/Users/jk1/temp/fmri_test/atlas/FSL_MNI152_FreeSurferConformed_1mm.nii.gz')


# if __name__ == '__main__':
#     parser = argparse.ArgumentParser(description='Coregister 4D file to reference file')
#     parser.add_argument('input_file')
#     parser.add_argument('-struct', action="store", dest='struct', help='Structural file')
#     parser.add_argument('-ref', action="store", dest='ref', help='Reference file to coregister and normalize to')
#     args = parser.parse_args()
#     register_and_normalize(args.input_file, args.struct, args.ref)

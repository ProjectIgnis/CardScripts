--青眼の究極竜
--Blue-Eyes Ultimate Dragon (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	local e0=Fusion.AddProcMixN(c,true,true,CARD_BLUEEYES_W_DRAGON,3)[1]
	e0:SetDescription(aux.Stringid(id,0))
	local e1=Fusion.AddProcMix(c,true,true,CARD_BLUEEYES_W_DRAGON,s.ffilter)[1]
	e1:SetDescription(aux.Stringid(id,1))
end
s.material_setcode=SET_BLUE_EYES
s.listed_names={CARD_BLUEEYES_W_DRAGON}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsHasEffect(160319004)
end
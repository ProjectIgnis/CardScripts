--月光狼
--Lunalight Wolf
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum summon
	Pendulum.AddProcedure(c)
	--Prevent pendulum summon of non-"Lunalight" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--Fusion summon
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_LUNALIGHT),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
					extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratarget}
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
	--Piercing damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.ptg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LUNALIGHT}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not (c:IsSetCard(SET_LUNALIGHT) and c:IsMonster()) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.ptg(e,c)
	return c:IsSetCard(SET_LUNALIGHT) and c:IsMonster()
end
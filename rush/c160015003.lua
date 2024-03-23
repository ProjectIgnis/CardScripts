--ダークネス・ドワーフ
--Darkness Dwarf
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 DARK monster
	local params = {aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),Fusion.OnFieldMat,nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(s.operation(Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_EXTRA,0,1,nil,tp,c)
end
function s.sumfilter(c,tp,excludecard)
	local fmg_all=Duel.GetFusionMaterial(tp)
	local mg=fmg_all:Filter(aux.FaceupFilter(Fusion.OnFieldMat),nil,e,tp,0)
	mg:RemoveCard(excludecard)
	return c:IsType(TYPE_FUSION) and c:CheckFusionMaterial(mg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp) end
end
function s.operation(oldop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
		if Duel.SendtoGrave(g,REASON_COST)==0 then return end
		oldop(e,tp,eg,ep,ev,re,r,rp)
	end
end
--センチネル・オフィサー
--Sentinel Officer
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {s.filter,nil,function(e,tp,mg) return nil,s.fcheck end}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(9)
end
function s.fcheck(tp,sg,fc)
	local mg1=sg:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)
	local mg2=sg:Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
	return #sg==2 and #mg1==1 and #mg2==1
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return #g>0 and not g:IsExists(aux.NOT(Card.IsRace),1,nil,RACE_GALAXY)
end
--プレデター・プライム・フュージョン
--Predaprime Fusion
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),Fusion.OnFieldMat,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PREDAPLANT}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PREDAPLANT),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.checkextra(tp,sg,fc)
	return sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.FilterBoolFunction(Card.IsControler,tp)),2,nil)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.checkextra
end
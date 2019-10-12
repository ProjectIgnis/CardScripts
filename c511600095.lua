--デストーイ・チェンジ・オブ・メモリー
--Frightfur Change of Memory
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activation)
	c:RegisterEffect(e1)
end
s.listed_series={0xad,0xa9,0xc3}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	return g:GetFirst():IsControler(tp)
end
function s.filter(c,re,rp,tf,ceg,cep,cev,cre,cr,crp)
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c)
end
function s.spfilter(c,e,tp,re)
	return (c:IsSetCard(0xad) or c:IsSetCard(0xa9) or c:IsSetCard(0xc3)) and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(re)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsCanBeEffectTarget(re) end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,re) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,re):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
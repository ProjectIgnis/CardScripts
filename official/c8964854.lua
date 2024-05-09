--コンビネーション・アタック
--Combination Attack
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_END)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_UNION}
function s.tgfilter(c,e,tp)
	if c:GetAttackAnnouncedCount()==0 then return false end
	local g=c:GetEquipGroup():Filter(s.spfilter,nil,e,tp)
	if #g==0 or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return false end
	local g1,g2=g:Split(Card.IsControler,nil,tp)
	return (#g1==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g1) and (#g2==0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=#g2)
end
function s.spfilter(c,e,tp)
	return c:IsHasEffect(EFFECT_UNION_STATUS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetControler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local g=tc:GetEquipGroup():Filter(s.spfilter,nil,e,tp)
	if #g==0 or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return false end
	for tc in g:Iter() do
		Duel.SpecialSummonStep(tc,0,tp,tc:GetControler(),false,false,POS_FACEUP)
	end
	if Duel.SpecialSummonComplete()==0 then return end
	--The monster that was equipped with a Union monster can attack again this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(tc:GetAttackAnnouncedCount())
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end
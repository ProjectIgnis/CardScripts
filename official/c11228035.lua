--エクシーズ・ソウル
--Xyz Soul
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 Xyz Monster in either player's Graveyard; all monsters you currently control gain ATK equal to its Rank x 200, then you can shuffle it into the Extra Deck. This ATK increase lasts until the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsXyzMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsXyzMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsXyzMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	local atk=tc:GetRank()*200
	local atk_increase_chk=false
	for ac in g:Iter() do
		local prev_atk=ac:GetAttack()
		--All monsters you currently control gain ATK equal to its Rank x 200 until the end of this turn
		ac:UpdateAttack(atk,RESETS_STANDARD_PHASE_END,c)
		if not atk_increase_chk and ac:GetAttack()>prev_atk then
			atk_increase_chk=true
		end
	end
	if atk_increase_chk and tc:IsAbleToDeck() and aux.nvfilter(tc)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
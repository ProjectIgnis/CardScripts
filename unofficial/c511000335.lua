--Ojamable
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsPreviousPosition(POS_FACEUP) and #eg==1 and tc:IsControler(tp)
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsSetCard(0xf) and tc:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,2) end
	tc:CreateEffectRelation(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)	
	end
end

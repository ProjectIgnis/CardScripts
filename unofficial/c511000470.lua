--ドローラー
--Drawler
local s,id=GetID()
function s.initial_effect(c)
	--When this card is Normal Summoned, you can place any number of cards from your hand on the bottom of the Deck (in a random order) to have this card's ATK and DEF become equal to the number of returned cards x 500.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tdatkdeftg)
	e1:SetOperation(s.tdatkdefop)
	c:RegisterEffect(e1)
	--If this card destroys an Attack Position monster by battle, place the destroyed monster on the bottom of the Deck instead of sending it to the Graveyard.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c==e:GetHandler() and c:GetBattleTarget():IsAttackPos() end)
	e2:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e2)
end
function s.tdatkdeftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(Card.IsAbleToDeck,nil)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,0,0)
end
function s.tdatkdefop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hdct=Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(Card.IsAbleToDeck,nil)
	if hdct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,hdct,nil)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			c:UpdateAttack(ct*500,RESET_EVENT|RESETS_STANDARD_DISABLE)
			c:UpdateDefense(ct*500,RESET_EVENT|RESETS_STANDARD_DISABLE)
		end
	end
end

--冥府につづく階段
--Stairway to the Underworld
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a monster effect, or their monster declares an attack: Add up to 2 Level 7 or higher DARK monsters with 2500 DEF from your Deck to your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and re:IsMonsterEffect()
	end)
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(1-tp)
	end)
	c:RegisterEffect(e1b)
	--If a face-up DARK monster(s) you control is destroyed by battle or card effect while this card is in your GY: You can banish this card, then target 1 face-up monster your opponent controls; negate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.disablecon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.disabletg)
	e2:SetOperation(s.disableop)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefense(2500) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.disableconfilter(c,tp)
	return c:IsPreviousAttributeOnField(ATTRIBUTE_DARK) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.disablecon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.disableconfilter,1,nil,tp)
end
function s.disabletg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.disableop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:NegateEffects(e:GetHandler())
	end
end
--機怪神エクスクローラー
--Deus X-Krawler
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Negate the activation of an opponent's card or effect that targets this face-down card, and if you do, destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	-- e1:SetCondition(s.negcon)
	e1:SetCost(Cost.SelfChangePosition(POS_FACEUP_DEFENSE))
	e1:SetTarget(s.negtg)
	-- e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--After this card was flipped face-up, while it is in the Monster Zone, negate all monster effects activated on your opponent's field
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_FLIP)
	e2a:SetOperation(function(e)
				local c=e:GetHandler()
				c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
				local chain_link=Duel.GetCurrentChain()
				if chain_link==0 then return end
				local fid=c:GetFieldID()
				local tp=e:GetHandlerPlayer()
				--Workaround to have e2b apply immediately if it's flipped face-up due to its own effect
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_SOLVING)
				e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetCurrentChain()>chain_link and re:IsMonsterEffect() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and c:HasFlagEffect(id) and c:IsFaceup() and not c:IsDisabled() and c:IsFieldID(fid) end)
				e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
				e1:SetReset(RESET_CHAIN)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_CHAIN_SOLVED)
				e2:SetOperation(function() e1:Reset() e2:Reset() end)
				e2:SetReset(RESET_CHAIN)
				Duel.RegisterEffect(e2,tp)
			end)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_CHAIN_SOLVING)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():HasFlagEffect(id) and re:IsMonsterEffect() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE end)
	e2b:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2b)
	--Add 1 Level 9 monster with a different original Type and Attribute than this card from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and r&(REASON_BATTLE|REASON_EFFECT)>0 end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsFacedown() and Duel.IsChainNegatable(ev)) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.thfilter(c,race,attribute)
	return c:IsLevel(9) and c:IsAbleToHand() and not c:IsOriginalRace(race) and not c:IsOriginalAttribute(attribute)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace(),c:GetOriginalAttribute())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetOriginalRace(),c:GetOriginalAttribute())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Order of Hyperion
--AlphaKretin
function c210310055.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--reverse damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c210310055.recon)
	e2:SetValue(c210310055.rev)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67237709,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c210310055.drtg)
	e3:SetOperation(c210310055.drop)
	c:RegisterEffect(e3)
end
function c210310055.recon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x44)
end
function c210310055.rev(e,re,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return true end
	if bit.band(r,REASON_BATTLE)~=0 then
		local tp=e:GetHandlerPlayer()
		local bc=rc:GetBattleTarget()
		if bc and bc:IsSetCard(0x44) and bc:IsControler(tp) then
			return true
		end
	end
	return false
end
function c210310055.drfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
function c210310055.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(c210310055.drfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c210310055.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(p,c210310055.drfilter,p,LOCATION_HAND+LOCATION_GRAVE,0,1,63,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(1-p,g)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		local ct=g:Filter(Card.IsPreviousLocation,nil,LOCATION_HAND):GetCount()
		Duel.ShuffleDeck(p)
		Duel.BreakEffect()
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
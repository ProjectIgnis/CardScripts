--クロック・ナイト Ｎｏ．１２
--Clock Knight No. 12
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn: You can toss a coin. If Heads, this card gains 1200 ATK until the End Phase. If Tails, destroy this card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tosstg)
	e1:SetOperation(s.tossop)
	c:RegisterEffect(e1)
	--Once per turn, you can negate the effects of a "Clock Knight" monster requiring a coin toss and redo the coin toss.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={0x1530} --"Clock Knight" archetype
function s.tosstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.tossop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local res=Duel.TossCoin(tp,1)
		if res==COIN_HEADS then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1200)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		elseif res==COIN_TAILS then
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and c:GetFlagEffect(id)==0 and re:GetHandler():IsSetCard(0x1530) then
		return true
	else return false end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)>0 then return end
	if Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		Duel.TossCoin(tp,ev)
	end
end

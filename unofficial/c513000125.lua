--霧の王城 (Anime)
--Fog Castle (Anime)
--Scripted by Keddy, rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1110)
	c:SetCounterLimit(0x1110,5)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.destg)
	e2:SetValue(s.desval)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabelObject(e2)
	e3:SetOperation(s.chkop)
	c:RegisterEffect(e3)
	--recycle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(c:Alias(),1))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
function s.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.dfilter,nil,tp)
	if chk==0 then return #g>0 end
	g:KeepAlive()
	e:SetLabelObject(g)
	return Duel.SelectEffectYesNo(tp,e:GetHandler())
end
function s.desval(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	for tc in aux.Next(e:GetLabelObject()) do
		local dis=1<<tc:GetSequence()
		local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		if zone then Duel.MoveSequence(tc,math.log(zone,2)) end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_FZONE)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(s.disop)
		e1:SetLabel(dis)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		e:SetLabel(e:GetLabel()+dis)
		c:AddCounter(0x1110,1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
	end
end
function s.chkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=5-c:GetCounter(0x1110)<Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local dz=c:GetCounter(0x1110)>0 and c:GetFlagEffect(id)~=c:GetCounter(0x1110)
	if (tg or dz) and e:GetLabel()==0 then Duel.Hint(HINT_CARD,tp,id) end
	if tg then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)+c:GetCounter(0x1110)-5
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,ct,ct,nil)
		Duel.SendtoGrave(g,REASON_RULE)
	end
	if dz then
		local eff=e:GetLabelObject()
		local ft=c:GetCounter(0x1110)-c:GetFlagEffect(id)
		if ft<0 then
			c:ResetEffect(RESET_DISABLE,RESET_EVENT)
			e:SetLabel(~eff:GetLabel())
			eff:SetLabel(0)
		else
			for i=1,ft do
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
			end
			local dis=Duel.SelectDisableField(tp,ft,LOCATION_MZONE,0,e:GetLabel())
			eff:SetLabel(eff:GetLabel()+dis)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_FZONE)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetOperation(s.disop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			e1:SetLabel(dis)
			c:RegisterEffect(e1)
			e:SetLabel(0)
			Duel.Readjust()
		end
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1110)>=5
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if chk==0 then return #hg>0 and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==#hg
		and e:GetHandler():IsAbleToGraveAsCost() end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,4,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Sayuri·Desire Awake
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765907)
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,m)
	e2:SetCost(cm.thcost)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.target0)
	e1:SetOperation(cm.operation0)
	c:RegisterEffect(e1)
end
function cm.f(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.sayuri_trigger_condition(c,e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.f,tp,0,LOCATION_ONFIELD,1,nil)
end
function cm.sayuri_trigger_operation(c,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cm.f,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cm.thfilter(c)
	return Senya.check_set_sayuri(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetActivateEffect()
end
function cm.target0(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and cm.filter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,e:GetHandler())
end
function cm.operation0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) or not sc:IsRelateToEffect(e) then return end
	if sc:IsFacedown() then Duel.ConfirmCards(tp,sc) end
	if sc:GetActivateEffect() then
		local l=sc:GetFlagEffectLabel(m)
		if l then
			sc:ResetFlagEffect(m)
			sc:RegisterFlagEffect(m,RESET_PHASE+PHASE_END,0,2,l+1)
		else
			sc:RegisterFlagEffect(m,RESET_PHASE+PHASE_END,0,2,1)
		end
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(m,2))
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetHintTiming(0x3c0)
		e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			return not Duel.CheckEvent(EVENT_CHAINING)
		end)
		e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
			e:SetLabel(1)
			local l=sc:GetFlagEffectLabel(m)
			if chk==0 then return l and l>0 end
			if l==1 then
				sc:ResetFlagEffect(m)
			else
				sc:SetFlagEffectLabel(l-1)
			end
			Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		end)
		e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then
				local te=e:GetLabelObject()
				local tg=te:GetTarget()
				return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
			end
			if chk==0 then
				if e:GetLabel()==0 then return false end
				e:SetLabel(0)
				return cm.CopySpellNormalFilter(sc)
			end
			e:SetLabel(0)
			local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			te:SetLabelObject(e:GetLabelObject())
			e:SetLabelObject(te)
		end)
		e2:SetOperation(Senya.CopyOperation)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(m,2))
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_CHAINING)
		e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
		e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
			e:SetLabel(1)
			local l=sc:GetFlagEffectLabel(m)
			if chk==0 then return l and l>0 end
			if l==1 then
				sc:ResetFlagEffect(m)
			else
				sc:SetFlagEffectLabel(l-1)
			end
			Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		end)
		e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then
				local te=e:GetLabelObject()
				local tg=te:GetTarget()
				return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
			end
			if chk==0 then
				if e:GetLabel()==0 then return false end
				e:SetLabel(0)
				return cm.CopySpellChainingFilter(sc,e,tp,eg,ep,ev,re,r,rp)
			end
			e:SetLabel(0)
			local te,ceg,cep,cev,cre,cr,crp
			local fchain=cm.CopySpellNormalFilter(sc)
			if fchain then
				te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
			else
				te=sc:GetActivateEffect()
			end
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			if tg then
				if fchain then
					tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
				else
					tg(e,tp,eg,ep,ev,re,r,rp,1)
				end
			end
			te:SetLabelObject(e:GetLabelObject())
			e:SetLabelObject(te)
		end)
		e3:SetOperation(Senya.CopyOperation)
		e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e3,true)
	end
end
function cm.CopySpellNormalFilter(c)
	return c:CheckActivateEffect(true,true,false)
end
function cm.CopySpellChainingFilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:CheckActivateEffect(true,true,false) then return true end
	local te=c:GetActivateEffect()
	if te:GetCode()~=EVENT_CHAINING then return false end
	local tg=te:GetTarget()
	if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then return false end
	return true
end
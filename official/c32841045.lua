--魔弾の射手 カスパール
--Magical Musketeer Caspar
local s,id=GetID()
function s.initial_effect(c)
	--activate from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	--to hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.chaincon)
	e0:SetOperation(s.chainop)
	c:RegisterEffect(e0)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
s.listed_series={0x108}
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(ev+2,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function s.thfilter(c,...)
	return c:IsSetCard(0x108) and not c:IsCode(...) and c:IsAbleToHand()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(1)==0 then
		e:GetHandler():RegisterFlagEffect(1,RESET_CHAIN,0,1)
		e:GetLabelObject():GetLabelObject():Clear()
	end
	if e:GetHandler():GetFlagEffect(ev+2)>0 then
		local g=e:GetLabelObject():GetLabelObject()
		g:AddCard(re:GetHandler())
		e:GetLabelObject():SetLabelObject(g)
		if e:GetHandler():GetFlagEffect(1)<=1 then
			e:GetHandler():RegisterFlagEffect(1,RESET_CHAIN,0,1)
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e:GetLabelObject(),0,tp,tp,0)
		end
	end
end
function s.chk(c,tp,e)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then e:SetLabel(0) return re==e and g and g:IsExists(s.chk,1,nil,tp,e) end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		e:SetLabel(g:Select(tp,1,1,nil):GetFirst():GetCardID())
	else
		e:SetLabel(g:GetFirst():GetCardID())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetCardFromCardID(e:GetLabel())
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,e:GetLabelObject(),tc:GetCode())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--魔弾の射手 ドクトル
--Magical Musketeer Doc
local s,id=GetID()
function s.initial_effect(c)
	--"Magical Musket" Spell/Trap can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MAGICAL_MUSKET))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	--Add 1 "Magical Musket" card from the GY to the hand
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop2)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetLabelObject(g)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_MAGICAL_MUSKET}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flageff={c:GetFlagEffectLabel(1)}
	local chainid=ev
	if flageff[1]==nil then return end
	local g=e:GetLabelObject()
	for _,i in ipairs(flageff) do
		if chainid==i then
			if c:GetFlagEffect(2)==0 then
				g:Clear()
				c:RegisterFlagEffect(2,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET|RESET_CHAIN),0,1)
				Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,0,0)
			end
			g:AddCard(re:GetHandler())
			return
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsColumn(seq,p,LOCATION_SZONE)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(1,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1,ev)
end
function s.thfilter(c,codes)
	return c:IsSetCard(SET_MAGICAL_MUSKET) and not c:IsCode(codes) and c:IsAbleToHand()
end
function s.chk(c,tp,e)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g:IsExists(s.chk,1,nil,tp,e) end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		e:SetLabel(g:Select(tp,1,1,nil):GetFirst():GetCode())
	else
		e:SetLabel(g:GetFirst():GetCode())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local codes={e:GetLabel()}
	if not #codes==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetLabelObject(),codes)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
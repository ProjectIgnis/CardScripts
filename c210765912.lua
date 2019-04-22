--Sayuri·Rise to be
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765912)
function cm.initial_effect(c)
	Senya.AddSummonMusic(c,m*16+3,SUMMON_TYPE_RITUAL)
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
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,2))
	e3:SetCategory(CATEGORY_ANNOUNCE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.discon)
	e3:SetTarget(cm.distg)
	e3:SetOperation(cm.disop)
	c:RegisterEffect(e3)
end
cm.sayuri_trigger_forced=true
function cm.sayuri_trigger_condition(c,e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil)
end
function cm.sayuri_trigger_operation(c,e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1)
	Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	Duel.ShuffleDeck(1-tp)
	Duel.BreakEffect()
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_DECK,nil)
	Duel.ConfirmCards(tp,dg)
	local g=dg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,g)
		Duel.ShuffleDeck(1-tp)
	end
	Duel.ShuffleHand(1-tp)
end
function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cm.thfilter(c,tc)
	return Senya.check_set_sayuri(c) and c:IsType((tc:GetType() & 0x7)) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil) end
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	if #hg==0 then return end
	local sg=hg:RandomSelect(tp,1)
	Duel.ConfirmCards(tp,sg)
	if not Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil,sg:GetFirst()) or not Duel.SelectYesNo(tp,m*16+1) then
		Duel.ShuffleHand(1-tp)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil,sg:GetFirst())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.ShuffleHand(1-tp)
end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or ep==tp then return false end
	return re:IsHasCategory(CATEGORY_DRAW) or re:IsHasCategory(CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_TOHAND)
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetReset(RESET_CHAIN)
	e3:SetLabel(ac)
	e3:SetDescription(cid)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==e:GetDescription()
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(Card.IsControler,nil,1-tp)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(m,0x1fe1000+RESET_CHAIN,0,1)
		end
	end)
	Duel.RegisterEffect(e3,tp)
	local e1=e3:Clone()
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==e:GetDescription()
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(cm.cf,tp,0,LOCATION_HAND,nil)
		if #g>0 then
			Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
			Duel.ConfirmCards(tp,g)
			local tg=g:Filter(cm.df,nil,e:GetLabel())
			Duel.SendtoDeck(tg,nil,1,REASON_EFFECT)
			Duel.ShuffleHand(1-tp)
		end
	end)
	Duel.RegisterEffect(e1,tp)
end
function cm.cf(c)
	return c:GetFlagEffect(m)>0
end
function cm.df(c,cd)
	return c:IsCode(cd) and c:IsAbleToGrave()
end
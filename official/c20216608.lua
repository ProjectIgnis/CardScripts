--ツッパリーチ
--Tilted Try
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Normal draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetLabel(0)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Effect draw
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e3:SetLabel(1)
	c:RegisterEffect(e3)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and eg:IsExists(aux.NOT(Card.IsPublic),1,nil)) then return false end
	local mode=e:GetLabel()
	return (mode==0 and r==REASON_RULE) or (mode==1 and r==REASON_EFFECT)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mode=e:GetLabel()
	local g=eg:Filter(aux.NOT(Card.IsPublic),nil)
	if chk==0 then return (mode==0 or c:IsAbleToGrave()) and ep==tp and #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:Select(tp,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.SetTargetCard(sg)
	if mode==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if e:GetLabel()==1 and Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
--奇跡の方舟 (Deck Master)
--Shinato's Ark (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.GetDeckMaster(tp) and Duel.GetDeckMaster(tp):IsOriginalCode(id) and Duel.GetFlagEffect(tp,id)<=0
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local c=e:GetOwner()
	c:SetTurnCounter(1) 
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	Duel.SendtoDeck(g,0,-2,REASON_EFFECT)
	g:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetLabelObject(g)
	e1:SetCondition(s.repcon)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,7)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetLabelObject(g)
	e2:SetLabel(1)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,7)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
	e3:SetLabelObject(g)
	e3:SetCondition(s.defcon)
	e3:SetOperation(s.defop)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,7)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e4:SetCountLimit(1)
	e4:SetLabelObject(e2)
	e4:SetCondition(s.checkcon)
	e4:SetOperation(s.checkop)
	e4:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,7)
	Duel.RegisterEffect(e4,tp)
end
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetDeckMaster(tp) and Duel.GetDeckMaster(tp):IsOriginalCode(id)
end
function s.repfilter(c)
	return c:GetDestination()==LOCATION_GRAVE and c:IsType(TYPE_MONSTER)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil) end
	local g=eg:Filter(s.repfilter,nil)
	Duel.SendtoDeck(g,0,-2,REASON_EFFECT)
	e:GetLabelObject():Merge(g)
	return true
end
function s.repval(e,c)
	return s.repfilter(c)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetDeckMaster(tp) and Duel.GetDeckMaster(tp):IsOriginalCode(id) and (#e:GetLabelObject()>0 or e:GetLabel()==1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=3
	if #e:GetLabelObject()==0 then
		op=2
	elseif e:GetValue()~=7 then
		if Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and #g==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) then
			op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		else
			op=0
		end  
	else
		if Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() then
			if #g==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) then
				op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
			else
				op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))*2
			end
		else
			op=0
		end   
	end
	if op==0 then
		Duel.ConfirmCards(tp,g)
	elseif op==1 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		g:Clear()
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.BreakEffect()
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	elseif op==2 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		e:GetOwner():Recreate(153000018)
		if not e:GetOwner():IsLocation(LOCATION_ONFIELD) then Duel.Hint(HINT_SKILL,tp,153000018) end
	end 
end
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_BATTLE,0,1)
	return Duel.IsTurnPlayer(1-tp) and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and #e:GetLabelObject()>=ct and Duel.GetDeckMaster(tp) and Duel.GetDeckMaster(tp):IsOriginalCode(id) and Duel.GetFlagEffect(tp,id+1)<=1
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local g=e:GetLabelObject()
	local tg=Group.CreateGroup()
	local randomNumbers={}
	while #randomNumbers<ct do
		randomNumbers[Duel.GetRandomNumber(1,ct)]=true
	end
	local i=1
	for c in aux.Next(g) do
		if randomNumbers[i] then
			tg:AddCard(c)
			g:RemoveCard(c)
		end
		i=i+1
	end
	for tc in aux.Next(tg) do
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_DEFENSE,true)
	end
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetDeckMaster(tp) and Duel.GetDeckMaster(tp):IsOriginalCode(id) and Duel.IsTurnPlayer(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	ct=ct+1
	e:GetLabelObject():SetLabel(ct)
end

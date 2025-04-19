--奇跡の方舟 (Deck Master)
--Shinato's Ark (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.IsDeckMaster(tp,id) and Duel.GetFlagEffect(tp,id)<=0
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local c=e:GetOwner()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.SendtoDeck(g,0,-2,REASON_EFFECT)
	g:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetLabelObject(g)
	e1:SetCondition(s.repcon)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetLabelObject(g)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
	e3:SetLabelObject(g)
	e3:SetCondition(s.defcon)
	e3:SetOperation(s.defop)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e4:SetCountLimit(1)
	e4:SetCondition(s.checkcon)
	e4:SetOperation(s.checkop)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetLabelObject(g)
	e5:SetCondition(s.gycon)
	e5:SetOperation(s.gyop)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TURN_END)
	e6:SetLabelObject(g)
	e6:SetCountLimit(1)
	e6:SetCondition(s.chcon)
	e6:SetOperation(s.chop)
	Duel.RegisterEffect(e6,tp)
	--Replace rule
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetValue(LOCATION_DECKBOT)
	e7:SetTargetRange(0xff,0xff)
	e7:SetTarget(s.repRuleTg)
	Duel.RegisterEffect(e7,tp)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_TO_DECK)
	e8:SetLabelObject(g)
	e8:SetOperation(s.repRuleOp)
	Duel.RegisterEffect(e8,tp)
end
function s.repRuleTg(e,c)
	if c:IsMonster() and c:IsReason(REASON_RULE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD&~(RESET_TODECK|RESET_LEAVE),0,1)
		return true
	else return false end
end
function s.rdfilter(c)
	return c:GetFlagEffect(id)>0 and c:IsMonster() and c:IsReason(REASON_RULE)
end
function s.repRuleOp(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.rdfilter,nil)
	if #g==0 then return end
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD&~(RESET_LEAVE))
		tc:RegisterEffect(e1)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(g,tp,-2,REASON_EFFECT)
	e:GetLabelObject():Merge(Duel.GetOperatedGroup():Filter(aux.NOT(Card.IsLocation),nil,LOCATION_ALL))
end
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>7 then
		e:Reset()
		return false
	end
	return Duel.IsDeckMaster(tp,id)
end
function s.repfilter(c)
	return c:GetDestination()&LOCATION_GRAVE==LOCATION_GRAVE and c:IsMonster()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil) end
	local g=eg:Filter(s.repfilter,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD&~(RESET_LEAVE))
		tc:RegisterEffect(e1)
	end
	Duel.SendtoDeck(g,tp,-2,REASON_EFFECT)
	e:GetLabelObject():Merge(Duel.GetOperatedGroup():Filter(aux.NOT(Card.IsLocation),nil,LOCATION_ALL))
	return true
end
function s.repval(e,c)
	return s.repfilter(c)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>7 then
		e:Reset()
		return false
	end
	return Duel.IsDeckMaster(tp,id)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
--OP:
--0 - Banish
--1 - Transform
--2 - Check Ark
--3 - Check Turn

--Strings:
--0 - 7 turns
--8 - Check Turn
--9 - Check Ark
--10 - Banish
--11 - Transform
	local op=4
	local g=e:GetLabelObject()
	if not Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() then
		if #e:GetLabelObject()==0 then
			Duel.SelectOption(tp,aux.Stringid(id,8))
			op=3
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,9),aux.Stringid(id,8))+2
		end
	else
		local seventhTurn=Duel.GetFlagEffect(tp,id)==7
		if #e:GetLabelObject()==0 then
			if not seventhTurn then
				Duel.SelectOption(tp,aux.Stringid(id,8))
				op=3
			else
				op=Duel.SelectOption(tp,aux.Stringid(id,11),aux.Stringid(id,8))*2+1
			end
		else
			local removeCheck=#g==g:FilterCount(Card.IsAbleToRemoveAsCost,nil)
			if not seventhTurn and not removeCheck then
				op=Duel.SelectOption(tp,aux.Stringid(id,9),aux.Stringid(id,8))+2
			elseif not seventhTurn then
				op=Duel.SelectOption(tp,aux.Stringid(id,10),aux.Stringid(id,9),aux.Stringid(id,8))
				if op>0 then op=op+1 end
			elseif not removeCheck then
				op=Duel.SelectOption(tp,aux.Stringid(id,11),aux.Stringid(id,9),aux.Stringid(id,8))*2-1
			else
				op=Duel.SelectOption(tp,aux.Stringid(id,10),aux.Stringid(id,11),aux.Stringid(id,9),aux.Stringid(id,8))
			end
		end
	end
	if op==0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		g:Clear()
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.BreakEffect()
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	elseif op==1 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		local c=Duel.GetDeckMaster(tp)
		c:Recreate(153000018,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
		if not c:IsLocation(LOCATION_ONFIELD) then Duel.Hint(HINT_SKILL,tp,153000018) end
		if g:GetFirst() then Duel.SendtoGrave(g,REASON_RULE) end
	elseif op==2 then
		Duel.ConfirmCards(tp,g)
	elseif op==3 then
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,Duel.GetFlagEffect(tp,id)))
	end 
end
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>7 then
		e:Reset()
		return false
	end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	Duel.RegisterFlagEffect(tp,id+PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,0,1)
	return Duel.IsTurnPlayer(1-tp) and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and #e:GetLabelObject()>=ct and Duel.IsDeckMaster(tp,id) and Duel.GetFlagEffect(tp,id+PHASE_BATTLE)<=1
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local g=e:GetLabelObject()
	for i=1,ct do
		local tc=g:TakeatPos(Duel.GetRandomNumber(1,#g)-1)
		if not tc then return end
		g:RemoveCard(tc)
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_DEFENSE,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		tc:RegisterEffect(e1)
	end
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>7 then
		e:Reset()
		return false
	end
	return Duel.IsDeckMaster(tp,id) and Duel.IsTurnPlayer(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>7 then
		e:GetLabelObject():DeleteGroup()
		Duel.ResetFlagEffect(tp,id)
		e:Reset()
		return false
	end
	return e:GetLabelObject():GetFirst() and not Duel.IsDeckMaster(tp,id)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_RULE)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==7 and Duel.IsTurnPlayer(tp) and Duel.IsDeckMaster(tp,id)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local c=Duel.GetDeckMaster(tp)
	c:Recreate(153000018,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	if not c:IsLocation(LOCATION_ONFIELD) then Duel.Hint(HINT_SKILL,tp,153000018) end
	if e:GetLabelObject():GetFirst() then Duel.SendtoGrave(e:GetLabelObject(),REASON_RULE) end
end
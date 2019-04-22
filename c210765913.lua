--Sayuri·Lunatic Blue
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765913)
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(Senya.SelfDiscardCost)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(cm.rettg)
	e3:SetOperation(cm.retop)
	c:RegisterEffect(e3)
end
cm.mat_filter=Senya.SayuriDefaultMaterialFilterLevel8
function cm.f(c)
	return c:IsFaceup() and c:IsCanTurnSet() and not Senya.CheckPendulum(c)
end
function cm.sayuri_trigger_condition(c,e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.f,tp,0,LOCATION_ONFIELD,1,nil)
end
function cm.sayuri_trigger_operation(c,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,cm.f,tp,0,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
			tc:CancelToGrave()
		end
		if tc:IsLocation(LOCATION_SZONE) then
			Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
function cm.filter(c)
	return c:IsAbleToRemove() and c:IsFaceup() and Senya.check_set_sayuri(c)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cm.filter(chkc) and c:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local pos=tc:GetPosition()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	if not tc:IsLocation(LOCATION_REMOVED) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetLabel(pos)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetOperation(function(e,tp)
		local c=e:GetHandler()
		local p=e:GetOwnerPlayer()
		if Duel.GetMZoneCount(p)>0 and c:IsType(TYPE_MONSTER) then
			Duel.MoveToField(c,p,p,LOCATION_MZONE,e:GetLabel(),true)
		else
			Duel.SendtoGrave(c,REASON_RULE)
		end
		e:Reset()
	end)
	tc:RegisterEffect(e1,true)   
end
function cm.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
end
function cm.getf(s,loc,g,e,tp)
	if s<0 or s>4 then return end
	local tc=Duel.GetFieldCard(1-tp,loc,s)
	if tc and not tc:IsImmuneToEffect(e) then g:AddCard(tc) end
end
function cm.move(c,co,e)
	Duel.HintSelection(Group.FromCards(c))
	if c:IsImmuneToEffect(e) then return end
	local s=c:GetSequence()
	if s==co then
		cm.exile(c,e)
	elseif s>co then
		if Duel.CheckLocation(c:GetControler(),c:GetLocation(),s-1) then
			Duel.MoveSequence(c,s-1)
		else
			cm.exile(c,e)
		end
	elseif s<co then
		if Duel.CheckLocation(c:GetControler(),c:GetLocation(),s+1) then
			Duel.MoveSequence(c,s+1)
		else
			cm.exile(c,e)
		end
	end
end
function cm.exile(c,e)
	if c:IsImmuneToEffect(e) then return end
	Senya.ExileCard(c)
	Duel.SendtoGrave(c,REASON_RULE+REASON_RETURN)
end
function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local co=c:GetSequence()
	if c:IsControler(tp) then
		if co==5 then co=3
		elseif co==6 then co=1
		else co=4-co end
	else
		if co==5 then co=1
		elseif co==6 then co=3 end
	end
	for j=5,6 do
		local pc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,j)
		if pc and pc:IsControler(1-tp) then
			Duel.HintSelection(Group.FromCards(pc))
			cm.exile(pc,e)
		end
	end
	for j=0,1 do
		local pc=Duel.GetFieldCard(1-tp,LOCATION_PZONE,j)
		if pc and pc:IsControler(1-tp) then
			Duel.HintSelection(Group.FromCards(pc))
			cm.exile(pc,e)
		end
	end
	local pc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if pc and pc:IsControler(1-tp) then
		Duel.HintSelection(Group.FromCards(pc))
		cm.exile(pc,e)
	end
	for i=0,4 do
		for loc=4,8,4 do
			local g=Group.CreateGroup()
			cm.getf(co+i,loc,g,e,tp)
			cm.getf(co-i,loc,g,e,tp)
			if #g==1 then
				cm.move(g:GetFirst(),co,e)
			elseif #g==2 then
				Duel.Hint(HINT_SELECTMSG,1-tp,m*16+2)
				local tc1=g:Select(1-tp,1,1,nil):GetFirst()
				g:RemoveCard(tc1)
				cm.move(tc1,co,e)
				local tc2=g:GetFirst()
				cm.move(tc2,co,e)
			end
		end
	end
end
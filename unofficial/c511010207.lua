--ＣＮｏ.１０７ 超銀河眼の時空龍 (Anime)
--Number C107: Neo Galaxy-Eyes Tachyon Dragon (Anime)
--Scripted By TheOnePharaoh, fixed by MLD & Larry126
Duel.LoadCardScript("c68396121.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,88177324)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Detach(1))
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Double Snare
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--Three attacks
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetCost(s.atkcost)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_RANKUP_EFFECT)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.startop)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={SET_NUMBER}
s.listed_names={88177324}
s.xyz_number=107
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc then
		rc:RegisterFlagEffect(511010207,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x7f,0x7f,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(511010208,RESET_PHASE|PHASE_END,0,1,tc:GetLocation())
		tc:RegisterFlagEffect(511010209,RESET_PHASE|PHASE_END,0,1,tc:GetControler())
		tc:RegisterFlagEffect(511010210,RESET_PHASE|PHASE_END,0,1,tc:GetPosition())
		tc:RegisterFlagEffect(511010211,RESET_PHASE|PHASE_END,0,1,tc:GetSequence())
	end
end
function s.filter(c)
	return c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:IsType(TYPE_EFFECT)) and not c:IsDisabled()
end
function s.retfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local nochk=false
	for tc in aux.Next(dg) do
		if not nochk then nochk=true end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
	local rg=Duel.GetMatchingGroup(s.retfilter,tp,0x7e,0x7e,e:GetHandler())
	for rc in aux.Next(rg) do
		if not nochk then nochk=true end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e2)
		if rc:GetFlagEffectLabel(id+1)==LOCATION_HAND then
			Duel.SendtoHand(rc,rc:GetFlagEffectLabel(511010209),REASON_EFFECT)
		elseif rc:GetFlagEffectLabel(id+1)==LOCATION_GRAVE then
			Duel.SendtoGrave(rc,REASON_EFFECT,rc:GetFlagEffectLabel(511010209))
		elseif rc:GetFlagEffectLabel(id+1)==LOCATION_REMOVED then
			Duel.Remove(rc,rc:GetPreviousPosition(),REASON_EFFECT,rc:GetFlagEffectLabel(511010209))
		elseif rc:GetFlagEffectLabel(id+1)==LOCATION_DECK then
			Duel.SendtoDeck(rc,rc:GetFlagEffectLabel(511010209),2,REASON_EFFECT)
		elseif rc:GetFlagEffectLabel(id+1)==LOCATION_EXTRA then
			Duel.SendtoDeck(rc,rc:GetFlagEffectLabel(511010209),0,REASON_EFFECT)
		else
			if rc:IsStatus(STATUS_LEAVE_CONFIRMED) then
				rc:CancelToGrave()
			end
			local loc=rc:GetFlagEffectLabel(id+1)
			if rc:IsType(TYPE_FIELD) then
				loc=LOCATION_FZONE
			end
			Duel.MoveToField(rc,rc:GetFlagEffectLabel(511010209),rc:GetFlagEffectLabel(511010209),loc,rc:GetFlagEffectLabel(511010210),true)
			if rc:GetSequence()~=rc:GetFlagEffectLabel(511010211) then
				Duel.MoveSequence(rc,rc:GetFlagEffectLabel(511010211))
			end
			if rc:GetPosition()~=rc:GetFlagEffectLabel(511010210) then
				Duel.ChangePosition(rc,rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),true,true)
			end
		end
		Duel.NegateRelatedChain(rc,RESET_TURN_SET)
	end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #sg>0 and (not nochk or Duel.SelectYesNo(tp,aux.Stringid(402568,0))) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(402568,0))
		local ssg=sg:Select(tp,1,63,nil)
		Duel.HintSelection(ssg)
		for sc in aux.Next(ssg) do
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,2))
			e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_TRIGGER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e3)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.rfilter(c)
	return c:GetAttackAnnouncedCount()<=0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.rfilter,2,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,s.rfilter,2,2,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
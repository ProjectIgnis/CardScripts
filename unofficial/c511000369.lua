--Number 100: Numeron Dragon
--By Edo9300
--atkup fixed by eclair
--forced trigger fixed by MLD
Duel.LoadCardScript("c57314798.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atk change
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--destroy and return
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--attack up
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.regcost)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
	--battle indestructable
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(s.indes)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetTarget(s.stcheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.xyz_number=100
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:GetControler()~=tp and at:IsType(TYPE_XYZ) and Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)==0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
function s.retfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetFlagEffect(id)>0
end
function s.retfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetFlagEffect(id)>0 
		and not Duel.IsExistingMatchingCard(function(c,seq)return c:GetSequence()==seq end,tp,LOCATION_SZONE,0,1,c,((c:GetFlagEffectLabel(id)&4)>>0xf))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,#sg1,0,0)
	local sg2=Duel.GetMatchingGroup(s.retfilter,tp,0x32,0x32,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg2,#sg2,0,0)
end
function s.fil(c,seq,p)
	local lab=c:GetFlagEffectLabel(id)
	return ((lab&4)>>0xf)==seq and ((lab&8)>>0xf)==p
end
function s.fil2(c,seq,p)
	return c:IsFaceup() and not (c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) or c:IsHasEffect(EFFECT_REMAIN_FIELD) or c:IsLocation(LOCATION_PZONE))
end
function s.transchk(c)
	return c:GetFlagEffectLabel(511000368)==0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Destroy(sg1,REASON_EFFECT)
	local sg2=Duel.GetMatchingGroup(s.retfilter2,tp,0x32,0x32,nil)
	--if sg2:IsExists(s.transchk,1,nil) then return end
	local tc=sg2:GetFirst()
	while tc do
		local lab=tc:GetFlagEffectLabel(id)
		local pos=(lab&0xf)
		local seq=((lab&4)>>0xf)
		local p=((lab&8)>>0xf)
		local pzone=((lab&16)>>0xf)
		local sgf=sg2:Filter(s.fil,nil,seq,p)
		if #sgf>1 then
			tc=sgf:Select(p,1,1,nil):GetFirst()
			sg2:Remove(s.fil,nil,seq,p)
		end
		if pzone==1 then
			if (seq==4 or seq==7) then seq=1
			else seq=0 end
		end
		local loc=LOCATION_SZONE
		if pzone==1 then loc=LOCATION_PZONE end
		Duel.MoveToField(tc,tp,p,loc,pos,true,(1<<seq))
		tc=sg2:GetNext()
	end
	Duel.SendtoGrave(sg2:Filter(s.fil2,nil),REASON_RULE)
end
function s.regcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(s.atkupop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.atkupop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetRank)*1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	e1:SetValue(atk)
	c:RegisterEffect(e1)
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
function s.stcheck(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			local pzone=0
			if tc:IsPreviousLocation(LOCATION_PZONE) then
				pzone=1
			end
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1,tc:GetPreviousPosition()+(tc:GetPreviousSequence()<<4)+(tc:GetPreviousControler()<<8)+(pzone<<16))
			tc=g:GetNext()
		end
	end
end

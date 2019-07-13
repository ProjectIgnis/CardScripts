--Blackwing - Gofu the Hazy Shadow
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95100147,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	--synlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(s.synlimit)
	c:RegisterEffect(e5)
	--material effect
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--graveyard synchro
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(id)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.synchk)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_DARK) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	Duel.SpecialSummonComplete()
end
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsLocation(LOCATION_GRAVE)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99946920,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.recon)
	e1:SetValue(LOCATION_DECK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end
function s.recon(e)
	return e:GetHandler():IsFaceup()
end
function s.regfilter(c)
	return c.synchro_type and c:IsType(TYPE_SYNCHRO) and c:GetFlagEffect(id+1)==0
end
function s.synchk(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.regfilter,tp,0xff,0xff,nil)
	local tc=sg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id+1,0,0,0)
		local tpe=tc.synchro_type
		local t=tc.synchro_parameters
		if tc.synchro_type==1 then
			local f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm=table.unpack(t)
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,s.reqm(reqm)))
			e1:SetTarget(Synchro.Target(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,s.reqm(reqm)))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		elseif tc.synchro_type==2 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(table.unpack(t),s.reqm()))
			e1:SetTarget(Synchro.Target(table.unpack(t),s.reqm()))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		elseif tc.synchro_type==3 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(table.unpack(t),s.reqm()))
			e1:SetTarget(Synchro.Target(table.unpack(t),s.reqm()))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		end
		tc=sg:GetNext()
	end
end
function s.reqm(reqm)
	return	function(g,sc,tp)
				return g:IsExists(Card.IsHasEffect,1,nil,id) and (not reqm or reqm(g,sc,tp))
			end
end

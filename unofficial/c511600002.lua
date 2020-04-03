--次元领域决斗
--Dimension Duel
--scripted by Larry126
--note: Please contact with me if wanting to edit this script
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(0xff)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	--check if number of card >20 if speed duel or >40 if other duel
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,0xff,0xff,1,nil,511004001)
		and Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND+LOCATION_DECK,0,c)<20 then
		return Duel.Win(1-tp,0x60)
	elseif Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND+LOCATION_DECK,0,c)<40 
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,0xff,0xff,1,nil,511004001) then
		return Duel.Win(1-tp,0x60)
	end
	if Duel.GetFlagEffect(tp,id)==0 and Duel.GetFlagEffect(1-tp,id)==0 then
		if c:IsLocation(LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED) and c:IsFacedown() then
			Duel.ConfirmCards(tp,c)
		end
		Duel.ConfirmCards(1-tp,c)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
	--limit summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.limitcon)
		e1:SetOperation(s.limitop)
		Duel.RegisterEffect(e1,tp)
	--Damage
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DESTROYED)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTarget(s.damcon)
		e2:SetOperation(s.damop)
		Duel.RegisterEffect(e2,tp)
	--no battle damage
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetTargetRange(1,1)
		e3:SetCondition(s.bcon)
		Duel.RegisterEffect(e3,tp)
	--Dimension Summon any level
		local limeff=Effect.CreateEffect(c)
		limeff:SetDescription(aux.Stringid(72497366,0))
		limeff:SetType(EFFECT_TYPE_FIELD)
		limeff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		limeff:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
		limeff:SetCondition(s.ntcon)
		for _,proc in ipairs({EFFECT_LIMIT_SUMMON_PROC,EFFECT_SUMMON_PROC}) do
			local leff=limeff:Clone()
			leff:SetCode(proc)
			Duel.RegisterEffect(leff,0)
		end
		limeff:Reset()
	--spirit
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_SUMMON_SUCCESS)
		e6:SetTarget(s.spttg)
		e6:SetOperation(s.sptop)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		Duel.RegisterEffect(e6,tp)
		local e7=e6:Clone()
		e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(e7,tp)
		local e8=e6:Clone()
		e8:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e8,tp)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	if c:IsPreviousLocation(LOCATION_HAND) then
		Duel.Draw(tp,1,REASON_RULE)
	end
	e:Reset()
end
function s.limitfilter(c)
	return c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) and c:GetFlagEffect(51160002)<=0
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.limitfilter,tp,0xff,0xff,1,nil)
end
function s.limitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.limitfilter,tp,0xff,0xff,nil)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(51160002,0,0,0)
		end
	end
end
------------------------------------------------------------------------
--tribute
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
------------------------------------------------------------------------
--spirit charge
function s.sptfilter(c)
	return c:IsType(TYPE_MONSTER+TYPE_TRAPMONSTER+TYPE_TOKEN) and c:IsOnField()
end
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.sptfilter,1,nil) end
end
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.sptfilter,nil)
	for tc in aux.Next(g) do
		local baseAtk=0
		local baseDef=0
		local textAtk=tc:GetTextAttack()
		local textDef=tc:GetTextDefense()
		local ctl=tc:GetControler()
		if textAtk~=-2 and textAtk~=0 then
			Duel.Hint(HINT_SELECTMSG,ctl,aux.Stringid(4010,4))
			local atkop=Duel.SelectOption(ctl,aux.Stringid(4010,1),aux.Stringid(4010,2),aux.Stringid(4010,3))
			if atkop==0 then
				baseAtk=textAtk
			elseif atkop==1 then
				baseAtk=0
			elseif atkop==2 then
				baseAtk=aux.ComposeNumberDigitByDigit(ctl,0,textAtk)
			end
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(baseAtk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
		if textDef~=-2 and textDef~=0 then
			Duel.Hint(HINT_SELECTMSG,ctl,aux.Stringid(4010,5))
			local defop=Duel.SelectOption(ctl,aux.Stringid(4010,1),aux.Stringid(4010,2),aux.Stringid(4010,3))
			if defop==0 then
				baseDef=textDef
			elseif defop==1 then
				baseDef=0
			elseif defop==2 then
				baseDef=aux.ComposeNumberDigitByDigit(ctl,0,textDef)
			end
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(baseDef)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
			tc:RegisterEffect(e2)
		end
	end
end
------------------------------------------------------------------------
--inflict battle damage
function s.damfilter(c)
	return c:IsType(TYPE_MONSTER+TYPE_TRAPMONSTER+TYPE_TOKEN) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.damfilter,nil)
	local dam1=0
	local dam2=0
	if #g<1 then return end
	local tc=g:GetFirst()
	while tc do
		local def=tc:GetPreviousDefenseOnField()
		local atk=tc:GetPreviousAttackOnField()
		local ctl=tc:GetControler()
		if tc:IsPreviousPosition(POS_ATTACK) then
			Duel.Damage(ctl,atk,REASON_RULE,true)
		elseif tc:IsPreviousPosition(POS_DEFENSE) then
			Duel.Damage(ctl,def,REASON_RULE,true)
		end
		tc=g:GetNext()
	end
	Duel.RDComplete()
end
------------------------------------------------------------------------
--no battle damaged
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil
end
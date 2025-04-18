--アモルファージ・イリテュム
--Amorphage Goliath
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Flag any "Amorphage" monster that would leave your field to exclude them in the banish effect's condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.amorphreg)
	c:RegisterEffect(e0)
	--Any card sent to the GY is banished instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(function(e,_c) return not _c:IsOriginalSetCard(SET_AMORPHAGE) and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),_c) end)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Maintenance cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetOperation(s.maintop)
	c:RegisterEffect(e2)
	--Neither player can Special Summon monsters from the Extra Deck, except "Amorphage" monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(function(e,_c) return _c:IsLocation(LOCATION_EXTRA) and not _c:IsSetCard(SET_AMORPHAGE) end)
	c:RegisterEffect(e3)
	--Clock Lizard check
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,function(e,_c) return not _c:IsOriginalSetCard(SET_AMORPHAGE) end,LOCATION_ALL,LOCATION_ALL)
end
s.listed_series={SET_AMORPHAGE}
function s.amorphreg(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsSetCard(SET_AMORPHAGE) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
			and tc:IsControler(tp) then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		end
	end
end
function s.rmconfilter(c)
	return c:IsSetCard(SET_AMORPHAGE) and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.rmcon(e)
	return Duel.IsExistingMatchingCard(s.rmconfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.maintop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	local b1=Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c)
	local b2=true
	--Tribute 1 monster or destroy this card
	local op=b1 and Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)}) or 2
	if op==1 then
		local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,1,1,c)
		Duel.Release(g,REASON_COST)
	elseif op==2 then
		Duel.Destroy(c,REASON_COST)
	end
end
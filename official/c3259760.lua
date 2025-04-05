--呪縛衆
--Spellbound
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Prevent the opponent's monster from being Tributed or used as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
local sumtypes={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK}
function s.filter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0 and s.CanBeTributeOrMaterial(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #sg==0 then return end
	local c=e:GetHandler()
	for tc in sg:Iter() do
		--Affected monster cannot be tributed
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		--Affected monster cannot be use as material
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.CanBeTributeOrMaterial(c)
	for _,sumtyp in ipairs(sumtypes) do
		if c:IsCanBeMaterial(sumtyp) then
			return true
		end
	end
	if not (c:IsHasEffect(EFFECT_UNRELEASABLE_SUM) or c:IsHasEffect(EFFECT_UNRELEASABLE_NONSUM)) then
		return true
	end
	return false
end
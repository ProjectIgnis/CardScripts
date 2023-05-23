--ＳＮｏ．０ ホープ・ゼアル (Manga)
--Number S0: Utopic ZEXAL (Manga)
--scripted by Larry126
Duel.LoadScript("c420.lua")
Duel.LoadCardScript("c52653092.lua")
local s,id,alias=GetID()
local zexal={}
function s.initial_effect(c)
	if not c:IsStatus(STATUS_COPYING_EFFECT) then
		zexal[c]=true
	end
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,3)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	--cannot disable spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.effcon)
	c:RegisterEffect(e2)
	--summon success
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.spsumsuc)
	c:RegisterEffect(e3)
	--atk & def
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCondition(s.con)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x48}
s.xyz_number=0
function s.con(e,tp,eg,ep,ev,re,r,rp)
	for i=0,1 do
		return Duel.IsPlayerAffectedByEffect(i,EFFECT_CANNOT_SPECIAL_SUMMON)
	end
end
function s.splimit(target)
	return function (...)
		return (not target or target(...)) and not zexal[c]
	end
end
local effmap={}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	for i=0,1 do
		local effs={Duel.GetPlayerEffect(i,EFFECT_CANNOT_SPECIAL_SUMMON)}
		for _,eff in ipairs(effs) do
			local target=eff:GetTarget()
			if target==nil or not effmap[target] then
				eff:SetTarget(s.splimit(eff:GetTarget()))
				effmap[eff:GetTarget()]=true
			end
		end
	end
end
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsSetCard(SET_NUMBER_S,xyz,sumtype,tp)
end
function s.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.atkval(e,c)
	return c:GetOverlayGroup():GetSum(Card.GetRank)*500
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
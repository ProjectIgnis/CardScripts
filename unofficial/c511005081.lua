--帝王の再覚醒
--Reawakening of the Emperor
--scripted by Shad3 and MLD
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Reactivate 1 Tribute Summoned Level 5 or higher "Monarch" monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsMonsterEffect() and re:GetCode()==EVENT_SUMMON_SUCCESS and rc:IsTributeSummoned() then
		rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsMonarch()
		and c:IsTributeSummoned() and c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g,true)
		Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,r,rp,ep,0)
	end
end
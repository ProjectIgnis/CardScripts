--決闘竜 デュエル・リンク・ドラゴン
--Duel Link Dragon, the Duel Dragon
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	--Special Summon 1 "Duel Dragon Token"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--Cannot be battle targeted while you control "Duel Dragon Token"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	--Cannot be targeted by the opponent's effects while you control "Duel Dragon Token"
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.listed_series={SET_POWER_TOOL}
s.listed_names={60025884}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO,lc,sumtype,tp)
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c,e,tp,zone)
	local lv=c:GetLevel()
	return (c:IsSetCard(SET_POWER_TOOL) or ((c:GetLevel()==7 or c:GetLevel()==8) and c:IsRace(RACE_DRAGON)))
		and c:IsType(TYPE_SYNCHRO) and lv>0 and c:IsAbleToRemoveAsCost()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,c:GetAttack(),c:GetDefense(),lv,c:GetRace(),c:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetFreeLinkedZone()&ZONES_MMZ
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return zone>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,zone)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,zone)
	local tc=g:GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabelObject(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetFreeLinkedZone()&ZONES_MMZ
	if zone==0 then return end
	local tc=e:GetLabelObject()
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		local token=Duel.CreateToken(tp,id+1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetDefense())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetLevel())
		token:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetRace())
		token:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetAttribute())
		token:RegisterEffect(e5)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id+1),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
--バトルドローン・ジェネラル
--Battledrone General
--fixed by Larry126
--cleaned up by MLD
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ "Drone" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx2(Card.IsDrone),2)
	--Once per turn: You can target 1 "Drone" monster in your GY; Special Summon it to your zone this card points to. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Once per turn, during your Main Phase 1: You can target 1 Level 4 or lower "Drone" monster you control with 1000 or less ATK; it can attack directly this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return Duel.IsPhase(PHASE_MAIN1) end)
	e2:SetTarget(s.s.diratktg)
	e2:SetOperation(s.s.diratkop)
	c:RegisterEffect(e2)
	-- If your "Drone" monster inflicts battle damage to your opponent by a direct attack: You can Tribute that monster; inflict damage to your opponent equal to the ATK that monster had on the field.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_series={0x581} --"Drone" archetype
function s.spfilter(c,e,tp,zone)
	return c:IsDrone() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,zone) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and zone~=0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
function s.diratkfilter(c)
	return c:IsFaceup() and c:IsDrone() and c:IsLevelBelow(4) and c:IsAttackBelow(1000) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
function s.diratktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.diratkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.diratkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.diratkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	e:SetLabelObject(eg:GetFirst())
	return rc:IsControler(tp) and rc:IsDrone() and Duel.GetAttackTarget()==nil
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetLabelObject()
	if chk==0 then return rc and rc:IsReleasable() end
	e:SetLabel(rc:GetAttack())
	Duel.Release(rc,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,ev)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

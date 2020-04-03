--デンジャラス・デストーイ・ナイトメアリー
--Dangerous Frightfur Nightmary
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc3),1,aux.FilterBoolFunctionEx(Card.IsSetCard,0xa9),2)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--mill
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={0xc3,0xa9,0xad}
function s.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,RACE_FAIRY+RACE_FIEND)*300
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.gyfilter(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
		and (c:IsSetCard(0xc3) or c:IsSetCard(0xa9) or c:IsSetCard(0xad))
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetBattleTarget():GetLevel()
	if chk==0 then 
		return lv>0 and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,lv,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,lv,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetHandler():GetBattleTarget():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,lv,lv,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainDisablable(ev) then return false end
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
function s.disfilter(c)
	return c:IsSetCard(0xad) and c:IsAbleToRemoveAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

--Ｋ９－６６６号 “Ｊａｃｋｓ”
--K9-666 "Jacks"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 5 monsters
	Xyz.AddProcedure(c,nil,5,2)
	--Destroy 1 monster on the field
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DESTROY)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1a:SetCost(Cost.DetachFromSelf(1))
	e1a:SetTarget(s.destg)
	e1a:SetOperation(s.desop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(s.descon)
	c:RegisterEffect(e1b)
	--A "K9" Xyz Monster that has this card as material gains this effect: ● During any turn in which your opponent has activated a monster effect in the hand or GY, any battle damage this card inflicts to your opponent is doubled
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.doubledamcon)
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={SET_K9}
function s.chainfilter(re,tp,cid)
	return not (re:IsMonsterEffect() and re:GetActivateLocation()&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp,chk)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_HAND|LOCATION_GRAVE)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.doubledamcon(e)
	local c=e:GetHandler()
	return c:IsSetCard(SET_K9) and c:IsXyzMonster() and Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0
end
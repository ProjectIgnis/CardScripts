--Shadow Fiend of the Wicked
--concept by Gideon
--scripted by Larry126
function c210660022.initial_effect(c)
	c:SetUniqueOnField(1,0,210660022)
	--fusion
	c:EnableReviveLimit()
	aux.AddFusionProcMixN(c,true,true,c210660022.matfilter,2)
	--synchro summon success
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c210660022.drcon)
	e1:SetTarget(c210660022.drtarg)
	e1:SetOperation(c210660022.drop)
	c:RegisterEffect(e1)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetTarget(c210660022.rmtg)
	e4:SetOperation(c210660022.rmop)
	c:RegisterEffect(e4)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c210660022.actcon)
	e3:SetValue(c210660022.actlimit)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210660022,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c210660022.bcon)
	e4:SetTarget(c210660022.btg)
	e4:SetOperation(c210660022.bop)
	c:RegisterEffect(e4)
	--salvage
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCost(c210660022.spcost)
	e5:SetTarget(c210660022.sptg)
	e5:SetOperation(c210660022.spop)
	c:RegisterEffect(e5)
	--recycle
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(17328157,1))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCondition(aux.exccon)
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(c210660022.thtg)
	e6:SetOperation(c210660022.thop)
	c:RegisterEffect(e6)
end
function c210660022.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsLevel(10)
end
---------------------------------------------
function c210660022.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c210660022.drtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210660022.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
---------------------------------------------
function c210660022.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function c210660022.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsImmuneToEffect(e)
end
---------------------------------------------
function c210660022.bcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()
end
function c210660022.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler():GetBattleTarget(),1,0,0)
end
function c210660022.bop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
---------------------------------------------
function c210660022.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function c210660022.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not c:IsRelateToEffect(e) then return end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
---------------------------------------------
function c210660022.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
function c210660022.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660022.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c210660022.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c210660022.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210660022.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
---------------------------------------------
function c210660022.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210660022.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660022.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c210660022.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210660022.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
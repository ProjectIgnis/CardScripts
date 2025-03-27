--ＤＤカウント・サーベイヤー
--D/D Count Surveyor
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Tribute 2 monsters your opponent controls and another one gains ATK/DEF equal to the total ATK/DEF the Tributed monsters had on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.tributecon)
	e1:SetTarget(s.tributetg)
	e1:SetOperation(s.tributeop)
	c:RegisterEffect(e1)
	--Special Summon this card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.Discard(function(c) return c:IsSetCard(SET_DD) and c:IsMonster() end,true))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Add 1 "D/D" monster with 0 ATK or DEF from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DD,SET_DDD}
function s.tributeconfilter(c,tp)
	return c:IsPendulumSummoned() and c:IsSummonPlayer(tp) and c:IsSetCard(SET_DDD)
end
function s.tributecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tributeconfilter,1,nil,tp)
end
function s.rescon(sg,e,tp,mg)
	return (sg:GetClassCount(Card.GetAttribute)==1 or sg:GetClassCount(Card.GetRace)==1)
		and sg:IsExists(Card.IsReleasableByEffect,2,nil)
end
function s.tributetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,tg,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,tg,1,tp,0)
end
function s.tributeop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #tg~=3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=tg:FilterSelect(tp,Card.IsReleasableByEffect,2,2,nil)
	if #sg~=2 then return end
	Duel.HintSelection(sg)
	tg:RemoveCard(sg)
	local atk=sg:GetSum(Card.GetAttack)
	local def=sg:GetSum(Card.GetDefense)
	if Duel.Release(sg,REASON_EFFECT)==2 then
		local c=e:GetHandler()
		local atkdef_c=tg:GetFirst()
		if atk>0 then
			atkdef_c:UpdateAttack(atk,RESET_EVENT|RESETS_STANDARD,c)
		end
		if def>0 then
			atkdef_c:UpdateDefense(def,RESET_EVENT|RESETS_STANDARD,c)
		end
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_DD) and c:IsMonster() and c:IsAbleToHand() and (c:IsAttack(0) or c:IsDefense(0))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
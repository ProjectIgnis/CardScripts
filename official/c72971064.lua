--ＬＬ－アンサンブルー・ロビン
--Lyrilusc - Ensemblue Robin
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Procedure: 2+ Level 1 monsters
	Xyz.AddProcedure(c,nil,1,2,nil,nil,Xyz.InfiniteMats)
	--This card gains 500 ATK for each material attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return c:GetOverlayCount()*500 end)
	c:RegisterEffect(e1)
	--Return 1 of your opponent's Special Summoned monsters to your opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.retopthcon)
	e2:SetCost(Cost.Detach(1,1,nil))
	e2:SetTarget(s.retopthtg)
	e2:SetOperation(s.retopthop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Add 1 "Lyrilusc" monster from your GY to your hand, except this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.llthcon)
	e3:SetTarget(s.llthtg)
	e3:SetOperation(s.llthop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LYRILUSC}
function s.retopthfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)	and c:IsLocation(LOCATION_MZONE)
end
function s.retopthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.retopthfilter,1,nil,e,tp)
end
function s.retopthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.retopthfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.retopthfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=nil
	if #eg==1 then
		tc=eg:GetFirst()
		Duel.SetTargetCard(tc)
	else
		tc=eg:FilterSelect(tp,s.retopthfilter,1,1,nil,e,tp)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function s.retopthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.llthcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:GetPreviousControler()==c:GetOwner()
end
function s.llthfilter(c)
	return c:IsSetCard(SET_LYRILUSC) and c:IsMonster() and c:IsAbleToHand()
end
function s.llthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.llthfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.llthfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectTarget(tp,s.llthfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function s.llthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
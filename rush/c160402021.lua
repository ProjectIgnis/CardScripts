--ジョインテック・ラプトル
--Jointech Raptor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
end
function s.filter(c)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSpell()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	local g2=Duel.GetOperatedGroup()
	local dam=(g:FilterCount(s.filter,nil) + g2:FilterCount(s.filter,nil))*100
	local sg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if Duel.Damage(1-tp,dam,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil)
		and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sc=Group.Select(sg,tp,1,1,nil)
		if #sc==0 then return end
		Duel.HintSelection(sc,true)
		Duel.BreakEffect()
		Duel.ChangePosition(sc,POS_FACEUP_DEFENSE)
	end
end
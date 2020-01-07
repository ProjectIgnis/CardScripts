--タンホイザーゲート
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()
end
function s.desfilter(c,atk,g)
	return (c:IsFacedown() or not c:IsType(TYPE_FUSION)) and c:IsDestructable() and c:IsAttackBelow(atk) and not g:IsContains(c) 
		and (c:GetSummonType()&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	local atk=g:GetSum(Card.GetAttack)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk,g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	local pct=0
	if g:IsExists(Card.IsControler,1,nil,tp) then
		pct=pct+1
	end
	if g:IsExists(Card.IsControler,1,nil,1-tp) then
		pct=pct+2
	end
	if pct==1 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,atk)
	elseif pct==2 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	else
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,atk)
	end
end
function s.damfilter(c,tp)
	return c:IsControler(tp) and not c:IsLocation(LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	local atk=g:GetSum(Card.GetAttack)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk,g)
	Duel.Destroy(sg,REASON_EFFECT)
	if sg:IsExists(s.damfilter,1,nil,tp) then
		Duel.Damage(tp,atk,REASON_EFFECT)
	end
	if sg:IsExists(s.damfilter,1,nil,1-tp) then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end

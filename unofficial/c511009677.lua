--Sunavalon Force
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--no damage & spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--self destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(s.descon)
	c:RegisterEffect(e3)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.tgtg)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
s.listed_series={0x1157}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_BATTLED,true)
	if res and s.damcon(e,tp,teg,tep,tev,tre,tr,trp) and s.damtg(e,tp,teg,tep,tev,tre,tr,trp,0) then
		e:SetOperation(s.damop)
		s.damtg(e,tp,teg,tep,tev,tre,tr,trp,1)
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_PLAYER_TARGET)
	else
		e:SetOperation(nil)
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return d:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLinkMonster() and c:GetLink()>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetTargetPlayer(1-tp)
	local sg=g:GetMaxGroup(Card.GetLink)
	local tc=sg:GetFirst()
	local dam=tc:GetLink()*100
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=g:GetMaxGroup(Card.GetLink)
	if #sg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		sg=sg:Select(tp,1,1,nil)
	end
	local tc=sg:GetFirst()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=tc:GetLink()*100
	Duel.Damage(p,dam,REASON_EFFECT)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SUNAVALON)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.desfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.tgtg(e,c)
	return c:IsSetCard(SET_SUNAVALON) and c:IsLinkMonster()
end
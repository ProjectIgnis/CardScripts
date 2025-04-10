--青い涙の乙女
--Maiden of Blue Tears
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster Special Summoned by your opponent and inflict damage to your opponent equal to half its original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Keep track of all monsters that are Special Summoned
	aux.GlobalCheck(s,function()
		s.sumgroup=Group.CreateGroup()
		s.sumgroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.sumgreg)
		Duel.RegisterEffect(ge1,0)
	end)
	--Set 1 Normal Spell from your GY or banishment
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_EFFECT)>0 end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.sumgreg(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	end
	if Duel.GetCurrentChain()==0 then s.sumgroup:Clear() end
	s.sumgroup:Merge(eg)
	s.sumgroup:Remove(function(c) return not c:HasFlagEffect(id) end,nil)
	Duel.RaiseEvent(s.sumgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
end
function s.desfilter(c,tp,e)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.sumgroup:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) and s.desfilter(chkc,tp,e) end
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLinkMonster),tp,LOCATION_MZONE,0,1,nil) end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	if tc:IsFaceup() and tc:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,tc:GetBaseAttack()//2)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,0)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:GetBaseAttack()>0 then
		Duel.Damage(1-tp,tc:GetBaseAttack()//2,REASON_EFFECT)
	end
end
function s.setfilter(c)
	return c:IsNormalSpell() and c:IsFaceup() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)>0 then
		--It cannot be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_CANNOT_ACT|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
end
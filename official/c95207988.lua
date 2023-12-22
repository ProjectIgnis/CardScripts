--地縛共振
--Earthbound Resonance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Inflict damage equal to half of the ATK of the monster destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Keep track of the destroyed monsters
	aux.GlobalCheck(s,function()
		s.desgroup=Group.CreateGroup()
		s.desgroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.desgroupregop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Destroy 1 card on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descond)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonLocation(LOCATION_EXTRA)
		and c:GetAttack()>0 and (not e or c:IsCanBeEffectTarget(e))
end
function s.desgroupregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.cfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.desgroup:Clear() end
		s.desgroup:Merge(tg)
		s.desgroup:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		Duel.RaiseEvent(s.desgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.desgroup:Filter(s.cfilter,nil,e)
	if chkc then return g:IsContains(chkc) and s.cfilter(chkc,e) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,tc,1,0,tc:GetAttack())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local val=tc:GetAttack()//2
	if tc:IsRelateToEffect(e) and val>0 then
		Duel.Damage(tp,val,REASON_EFFECT,true)
		Duel.Damage(1-tp,val,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsAttribute(ATTRIBUTE_DARK) and d:IsType(TYPE_SYNCHRO) and d:IsSummonLocation(LOCATION_EXTRA)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
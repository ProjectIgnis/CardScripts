--ヤモイモリ
--Yamorimori
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Banish from GY + choice effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
--Banish from GY + choice effect
function s.mfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsMonster() and (c:IsControler(1-tp) or c:IsRace(RACE_REPTILE))
end
function s.mfilter2(c,tp)
	return c:IsControler(tp) and c:IsDestructable()
end
function s.mfilter3(c,tp)
	return c:IsControler(1-tp) and c:IsAttackAbove(1)
end
function s.rescon(sg,e,tp,mg)
	return sg:Filter(Card.IsCanChangePosition,nil):GetClassCount(Card.GetControler)==2
		or (sg:IsExists(s.mfilter2,1,nil,tp) and sg:IsExists(s.mfilter3,1,nil,tp))
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(s.mfilter,e,tp),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
	local check1=sg:IsExists(Card.IsCanChangePosition,2,nil)
	local check2=sg:IsExists(s.mfilter2,1,nil,tp) and sg:IsExists(s.mfilter3,1,nil,tp)
	local choice=Duel.SelectEffect(tp,
		{check1,aux.Stringid(id,1)},
		{check2,aux.Stringid(id,2)})
	if choice==1 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,2,tp,LOCATION_MZONE)
		e:SetCategory(CATEGORY_POSITION)
	elseif choice==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg:Filter(Card.IsControler,nil,tp),1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sg:Filter(Card.IsControler,nil,1-tp),1,tp,LOCATION_MZONE)
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	end
	e:SetLabel(choice)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local choice=e:GetLabel()
	if choice==1 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	elseif choice==2 then
		local g1,g2=g:Split(Card.IsControler,nil,tp)
		if Duel.Destroy(g1,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g2:GetFirst():RegisterEffect(e1)
		end
	end
end

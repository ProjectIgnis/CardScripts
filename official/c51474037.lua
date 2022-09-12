--ヤモイモリ
--Yamoimori
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Banish from GY + choice effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
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
function s.mfilter2(c,chk1,chk2,g2)
	return (chk1 and c:IsCanChangePosition() and g2:IsExists(Card.IsCanChangePosition,1,nil)) or (chk2 and c:IsDestructable() and g2:IsExists(Card.IsAttackAbove,1,nil,1))
end
function s.mfilter3(c,chk1,chk2)
	return (chk1 and c:IsCanChangePosition()) or (chk2 and c:IsAttackAbove(1))
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1,g2=Duel.GetMatchingGroup(aux.FaceupFilter(s.mfilter,e,tp),tp,LOCATION_MZONE,LOCATION_MZONE,nil):Split(Card.IsControler,nil,tp)
	if chk==0 and (#g1==0 or #g2==0) then return false end
	local check1=g1:IsExists(Card.IsCanChangePosition,1,nil) and g2:IsExists(Card.IsCanChangePosition,1,nil)
	local check2=g1:IsExists(Card.IsDestructable,1,nil) and g2:IsExists(Card.IsAttackAbove,1,nil,1)
	if chk==0 then return check1 or check2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc1=g1:FilterSelect(tp,s.mfilter2,1,1,nil,check1,check2,g2):GetFirst()
	Duel.SetTargetCard(tc1)
	check1=check1 and tc1:IsCanChangePosition()
	check2=check2 and tc1:IsDestructable()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc2=g2:FilterSelect(tp,s.mfilter3,1,1,nil,check1,check2):GetFirst()
	Duel.SetTargetCard(tc2)
	check1=check1 and tc2:IsCanChangePosition()
	check2=check2 and tc2:GetAttack()>0
	local t={}
	if not check1 and not check2 then return end
	if check1 then table.insert(t,aux.Stringid(id,1)) end
	if check2 then table.insert(t,aux.Stringid(id,2)) end
	local choice=Duel.SelectOption(tp,table.unpack(t))+(check1 and 0 or 1)
	if choice==0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,Group.FromCards(tc1,tc2),2,tp,LOCATION_MZONE)
	elseif choice==1 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc1,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc2,1,tp,LOCATION_MZONE)
	end
	e:SetLabel(choice)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local choice=e:GetLabel()
	if choice==0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	elseif choice==1 then
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

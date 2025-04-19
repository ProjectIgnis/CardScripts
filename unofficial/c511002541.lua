--ヘル・ブラスト (Anime)
--Chthonian Blast (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 face-up monster on the field, and if you do, inflict damage to your opponent equal to half its ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(_,tp) return s[tp] end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop1)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]=false
		end)
	end)
end
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) then
			s[tc:GetPreviousControler()]=true
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	local dam=tc:GetAttack()/2
	if Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
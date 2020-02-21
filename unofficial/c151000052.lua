--ヴェノム・スワンプ (Action Field)
--Venom Swamp (Action Field)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Add counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--atk down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.af="a"
s.listed_series={0x50}
s.counter_place_list={0x1009}
function s.atkval(e,c)
	return c:GetCounter(0x1009)*-500
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Group.CreateGroup()
	local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		if tc:IsCanAddCounter(0x1009,1) and not tc:IsSetCard(0x50) then
			local atk=tc:GetAttack()
			tc:AddCounter(0x1009,1)
			if atk>0 and tc:GetAttack()==0 then
				g:AddCard(tc)
			end
		end
	end
	if #g>0 then
		Duel.RaiseEvent(g,EVENT_CUSTOM+id,e,0,0,0,0)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

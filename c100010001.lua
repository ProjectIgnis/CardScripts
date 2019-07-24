--ＮＯ１３ エーテリック・アメン
local s,id=GetID()
function s.initial_effect(c)
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)	
	--attack up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	--draw
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.con)
	e6:SetTarget(s.tg)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
end
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x95)
end
function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*100
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil)
	 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local dr=e:GetHandler():GetRank()-tc:GetRank()
		if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=dr then
			dr=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		end
		Duel.Overlay(e:GetHandler(),Duel.GetDecktopGroup(1-tp,dr))
	end
end
function s.gfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gfilter,1,nil,1-tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.gfilter,1,nil,1-tp) end
	Duel.SetTargetCard(eg)
end
function s.filter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp) and c:IsRelateToEffect(e)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	local dr=e:GetHandler():GetRank()-tc:GetRank()
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=dr then
		dr=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	end
	Duel.Overlay(e:GetHandler(),Duel.GetDecktopGroup(1-tp,dr))
end
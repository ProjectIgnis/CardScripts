--Overlay Assistance
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCondition(s.cd)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.xyz_sum_fil(c,p)
	return c:IsType(TYPE_XYZ) and c:GetControler()==p
end
function s.xyz_fup_fil(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.xyz_sum_fil,1,nil,1-tp) and Duel.GetFieldGroup(tp,LOCATION_HAND,0):GetCount()==0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.SelectMatchingCard(tp,s.xyz_fup_fil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not c then return end
	local i=c:GetOverlayCount()
	if i>0 then Duel.Draw(tp,i,REASON_EFFECT) end
end
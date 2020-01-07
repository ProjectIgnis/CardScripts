--Returning Light
--	by Snrk
--fixed by GameMaster
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(function (e) if e:GetHandler():IsDisabled() then e:SetLabel(1) else e:SetLabel(0) end end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end


function s.spfilter(c,sp)
return c:GetSummonPlayer()==sp
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,1-tp)
end


function s.exist(e,p) return Duel.IsExistingMatchingCard(s.ssf,p,LOCATION_GRAVE,0,1,nil,e,p) end
function s.ssf(c,e,p) return c:IsCanBeSpecialSummoned(e,0,p,false,false) and c:IsAttribute(ATTRIBUTE_LIGHT) end
function s.cf(c,p) return c:GetSummonPlayer()~=p end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) and chkc:GetAttribute()==ATTRIBUTE_LIGHT end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:Filter(s.cf,nil,tp) and s.exist(e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.op(e,tp)
	local c=e:GetHandler()
	if not s.exist(e,tp) or not c:IsRelateToEffect(e) then return end
	local tc=Duel.SelectMatchingCard(tp,s.ssf,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	Duel.Equip(tp,c,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function (e,c) return e:GetLabelObject()==c end)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
end
function s.desop(e)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
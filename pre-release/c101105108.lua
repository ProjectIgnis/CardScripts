--セイヴァー・ミラージュ
--Majestic Mirage
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.listed_names={id,44508094}
s.listed_series={0x3f}
--To Grave
function s.lffilter(c,r,rp,tp)
	return c:IsCode(44508094) or (aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SYNCHRO)) and rp==tp and ((r&REASON_EFFECT)==REASON_EFFECT or (r&REASON_COST)==REASON_COST)
end
function s.remfilter(c)
	return c:IsAbleToRemove() and c:IsMonster()
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lffilter,1,nil,r,rp,tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ss,rem,dam=eg:Filter(s.lffilter,nil,r,rp,tp):IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0,Duel.IsExistingMatchingCard(s.remfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,id+1)==0,Duel.GetFlagEffect(tp,id+2)==0
	local choice
	if ss and rem then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	elseif ss then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))+3
	elseif rem then choice=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+5
	else choice=Duel.SelectOption(tp,aux.Stringid(id,3))+7 end
	if choice==0 or choice==3 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	elseif choice==1 or choice==5 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_GRAVE+LOCATION_MZONE)
	end
	e:SetLabel(choice)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c,choice=e:GetHandler(),e:GetLabel()
	local tc
	if (choice==0 or choice==3) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0 then
		tc=eg:Filter(s.lffilter,nil,r,rp,tp):FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif (choice==1 or choice==5) and Duel.GetFlagEffect(tp,id+1)==0 then
		tc=Duel.SelectMatchingCard(tp,s.remfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	elseif Duel.GetFlagEffect(tp,id+2)==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
	else return
	end
end
function s.damval(e,re,ev,r,rp,rc)
	return math.floor(ev/2)
end
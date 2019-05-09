--Time Magic Hammer
local s,id=GetID()
function s.initial_effect(c)
        --fusion material
	c:EnableReviveLimit()
	Fusion.AddProcCodeFun(c,71625222,46232525,1,true,true)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
        --Future Swing
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_REPEAT)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
        e1:SetLabel(-1)
        e1:SetCondition(s.con)
        e1:SetOperation(s.act)
        c:RegisterEffect(e1)
    --Activate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Equip limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	    --Future Released
        local de=Effect.CreateEffect(c)
	de:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_LEAVE_FIELD)
	de:SetOperation(s.desop)
	c:RegisterEffect(de)
end
function s.hermos_filter(c)
	return c:IsCode(71625222)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsLocation(LOCATION_SZONE) and tc:IsLocation(LOCATION_MZONE) then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
        return Duel.GetTurnPlayer()~=tp
end
function s.filter(c,rc)
        return rc:GetCardTarget():IsContains(c) and c:GetFlagEffect(id)>0
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if e:GetLabel()==-1 then
            local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
            Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)
            local tg=Duel.GetOperatedGroup()
            e:SetLabel(#tg)
	    local tc=tg:GetFirst()
            while tc do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
                        c:SetCardTarget(tc)
			tc=tg:GetNext()
            end
        elseif e:GetLabel()>0 then
            if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
                local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,c)
                local sg=g:Select(1-tp,1,1,nil)
                local tc=sg:GetFirst()
                if tc and tc:IsLocation(LOCATION_REMOVED) then
                    Duel.ReturnToField(tc)
                    e:SetLabel(e:GetLabel()-1)
                end
            end
        end
end
function s.desop(e,tp,eg,ep,ev,re,rp)
        local c=e:GetHandler()
        local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,c)
        if #g>0 then
            if #g>Duel.GetLocationCount(1-tp,LOCATION_MZONE) then
                local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
                local sg=g:Select(1-tp,ft,ft,nil)
                local tc=sg:GetFirst()
                while tc do
                        Duel.ReturnToField(tc)
			tc=sg:GetNext()
                end
            else
                local tc=g:GetFirst()
                while tc do
                        Duel.ReturnToField(tc)
			tc=g:GetNext()
                end
            end
        end
end
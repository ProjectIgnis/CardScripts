--Ａｉの儀式
--A.I.'s Ritual
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),nil,nil,s.extrafil,nil,aux.FilterBoolFunction(Card.IsSetCard,0x135))
	local tg=e1:GetTarget()
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,...)
					if chk==0 then
						if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x135),tp,LOCATION_MZONE,0,1,nil) then
							e:SetLabel(1)
						else
							e:SetLabel(0)
						end
					end
					return tg(e,tp,eg,ep,ev,re,r,rp,chk,...)
				end)
	local op=e1:GetOperation()
	e1:SetOperation(function(e,...)
						local ret=op(e,...)
						if e:GetLabel()==1 then
							e:SetLabel(0)
						end
						return ret
					end)
	c:RegisterEffect(e1)
end
s.listed_series={0x135}
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
		and c:IsSetCard(0x135) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:GetLabel()==1 then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	end
end
